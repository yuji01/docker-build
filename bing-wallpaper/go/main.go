package main

import (
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"strconv"
	"time"
)

type BingResponse struct {
	Images []struct {
		UrlBase       string `json:"urlbase"`
		StartDate     string `json:"startdate"`
		Copyright     string `json:"copyright"`
		CopyrightLink string `json:"copyrightlink"`
	} `json:"images"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	// 随机参数判断
	randParam := r.URL.Query().Get("rand")
	dayParam := r.URL.Query().Get("day")

	var gettime int
	if randParam == "true" {
		rand.Seed(time.Now().UnixNano())
		gettime = rand.Intn(9) - 1 // -1 到 7
	} else {
		if dayParam != "" {
			n, err := strconv.Atoi(dayParam)
			if err != nil {
				gettime = 0
			} else {
				gettime = n
			}
		} else {
			gettime = 0
		}
	}

	// 请求 Bing 图片 API
	url := "https://bing.com/HPImageArchive.aspx?format=js&idx=" + strconv.Itoa(gettime) + "&n=1"
	resp, err := http.Get(url)
	if err != nil {
		http.Error(w, "无法获取 Bing 图片信息", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var bingData BingResponse
	if err := json.NewDecoder(resp.Body).Decode(&bingData); err != nil {
		http.Error(w, "解析 JSON 失败", http.StatusInternalServerError)
		return
	}

	if len(bingData.Images) == 0 {
		http.Error(w, "未获取到图片信息", http.StatusNotFound)
		return
	}

	image := bingData.Images[0]
	imgURLBase := "https://bing.com" + image.UrlBase

	// 处理图片大小参数
	sizeParam := r.URL.Query().Get("size")
	if sizeParam == "" {
		sizeParam = "1920x1080"
	}
	imgURL := imgURLBase + "_" + sizeParam + ".jpg"

	// 是否返回 JSON 信息
	if r.URL.Query().Get("info") == "true" {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"title": image.Copyright,
			"url":   imgURL,
			"link":  image.CopyrightLink,
			"time":  image.StartDate,
		})
		return
	}

	// 否则跳转到图片 URL
	http.Redirect(w, r, imgURL, http.StatusFound)
}

func main() {
	http.HandleFunc("/", handler)
	log.Println("服务启动，监听 :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
