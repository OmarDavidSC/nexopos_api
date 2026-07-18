<?php

namespace App\Services;

class SunatApiService
{
    private string $url;

    public function __construct()
    {
        $url = $_ENV['URL_API_SUNAT'] ?? '';

        if (empty($url)) {
            throw new \Exception('No se configuró la variable URL_API_SUNAT.');
        }

        $this->url = rtrim($url, '/');
    }

    public function emit(array $payload): array
    {
        return $this->request('/emit', 'POST', $payload);
    }

    public function document(string $documentId): array
    {
        return $this->request('/' . urlencode($documentId) . '/document', 'GET');
    }

    private function request(string $endpoint, string $method = 'POST', array $payload = []): array
    {
        $curl = curl_init();
        $jsonPayload = null;

        if ($method !== 'GET') {
            $jsonPayload = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

            if ($jsonPayload === false) {
                throw new \Exception('No se pudo convertir el payload SUNAT a JSON: ' . json_last_error_msg());
            }
        }

        $options = [
            CURLOPT_URL => $this->url . $endpoint,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_TIMEOUT => 60,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_MAXREDIRS => 5,
            CURLOPT_ENCODING => '',
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Accept: application/json',
            ],
        ];

        if ($jsonPayload !== null) {
            $options[CURLOPT_POSTFIELDS] = $jsonPayload;
        }

        curl_setopt_array($curl, $options);

        $rawResponse = curl_exec($curl);
        $curlError = curl_error($curl);
        $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        $contentType = curl_getinfo($curl, CURLINFO_CONTENT_TYPE);
        $finalUrl = curl_getinfo($curl, CURLINFO_EFFECTIVE_URL);

        curl_close($curl);

        if ($rawResponse === false) {
            throw new \Exception('No se pudo conectar con el módulo SUNAT: ' . ($curlError ?: 'Error desconocido.'));
        }

        $rawResponse = preg_replace('/^\xEF\xBB\xBF/', '', trim($rawResponse));
        $data = json_decode($rawResponse, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new \Exception(
                'Respuesta inválida del módulo SUNAT.'
                    . ' HTTP: ' . $httpCode
                    . ' | URL: ' . $finalUrl
                    . ' | Content-Type: ' . ($contentType ?: 'desconocido')
                    . ' | Error JSON: ' . json_last_error_msg()
                    . ' | Respuesta recibida: ' . substr($rawResponse, 0, 800)
            );
        }

        if (!is_array($data)) {
            throw new \Exception('El módulo SUNAT devolvió una respuesta JSON con formato inesperado.');
        }

        return [
            'http_code' => $httpCode,
            'response' => $data,
        ];
    }
}
