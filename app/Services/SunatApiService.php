<?php

namespace App\Services;

class SunatApiService
{
    private string $url;

    public function __construct()
    {
        $this->url = $_ENV['URl_API_SUNAT'];
    }

    public function emit(array $payload): array
    {
        return $this->request('/emit', 'POST', $payload);
    }

    public function document(string $documentId): array
    {
        return $this->request('/' . $documentId . '/document', 'GET');
    }

    private function request(string $endpoint, string $method = 'POST', array $payload = []): array
    {
        $curl = curl_init();

        $options = [
            CURLOPT_URL => $this->url . $endpoint,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_HTTPHEADER => ['Content-Type: application/json',],
        ];

        if ($method !== 'GET') {
            $options[CURLOPT_POSTFIELDS] = json_encode($payload, JSON_UNESCAPED_UNICODE);
        }

        curl_setopt_array($curl, $options);
        $response = curl_exec($curl);
        $error = curl_error($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);

        curl_close($curl);
        if ($error) {
            throw new \Exception('No se pudo conectar con el módulo SUNAT: ' . $error);
        }

        $data = json_decode($response, true);

        if (!is_array($data)) {
            throw new \Exception('El módulo SUNAT devolvió una respuesta inválida.');
        }

        return [
            'http_code' => $httpCode,
            'response' => $data,
        ];
    }
}
