package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/StackExchange/wmi"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

// BatteryStatus はWMIから取得するバッテリー情報の構造体
type BatteryStatus struct {
	EstimatedChargeRemaining uint32
}

// GetBatteryStatus はWMIを使用してバッテリー充電率を取得します
func GetBatteryStatus() (uint32, error) {
	var dst []BatteryStatus
	query := "SELECT EstimatedChargeRemaining FROM Win32_Battery"
	err := wmi.Query(query, &dst)
	if err != nil {
		return 0, err
	}
	if len(dst) > 0 {
		return dst[0].EstimatedChargeRemaining, nil
	}
	return 0, fmt.Errorf("battery information not found")
}

// CreateLogFile はログファイルを作成し、バッテリーの充電率を記録します
func CreateLogFile(charge uint32) (string, error) {
	// ログファイルの名前を作成（例: golang-desktop-sample-20250118123456.txt）
	fileName := fmt.Sprintf("golang-desktop-sample-%s.txt", time.Now().Format("20060102150405"))
	logFile, err := os.Create(fileName)
	if err != nil {
		return "", err
	}
	defer logFile.Close()

	// ログファイルに充電率を記録
	logFile.WriteString(fmt.Sprintf("Battery charge: %d%%\n", charge))
	return fileName, nil
}

// UploadToS3 はファイルを指定されたS3バケットにアップロードします
func UploadToS3(fileName string) error {
	// AWSセッションを作成
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"),
	})
	if err != nil {
		return err
	}

	// S3クライアントを作成
	svc := s3.New(sess)

	// ログファイルを読み込み
	fileContent, err := os.ReadFile(fileName)
	if err != nil {
		return err
	}

	// S3にファイルをアップロード
	_, err = svc.PutObject(&s3.PutObjectInput{
		Bucket: aws.String("shiun-test-bucket"), // S3バケット名
		Key:    aws.String(fileName),            // アップロードするファイル名
		Body:   bytes.NewReader(fileContent),    // ファイル内容
	})
	if err != nil {
		return err
	}

	fmt.Printf("File %s uploaded to S3 successfully\n", fileName)
	return nil
}

func main() {
	// バッテリー充電率を取得
	charge, err := GetBatteryStatus()
	if err != nil {
		log.Fatalf("Error getting battery status: %v", err)
	}

	// ログファイルを作成
	logFileName, err := CreateLogFile(charge)
	if err != nil {
		log.Fatalf("Error creating log file: %v", err)
	}

	// ログファイルをS3にアップロード
	err = UploadToS3(logFileName)
	if err != nil {
		log.Fatalf("Error uploading file to S3: %v", err)
	}

	// ローカルのログファイルを削除
	err = os.Remove(logFileName)
	if err != nil {
		log.Fatalf("Error deleting local log file: %v", err)
	}
}
