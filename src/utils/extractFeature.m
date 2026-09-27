function [nilaiMin, nilaiMax, nilaiMean, nilaiStd] = extractFeature(img)
%extractFeature - hitung min, max, mean, std dari citra grayscale (biar
%analisis atau compare di laporan mudah

%img : citra grayscale 2D, uint8
%nilaiMin, nilaiMax : intensitas piksel terendah/tertinggi yang muncul
%nilaiMean, nilaiStd : rata-rata & standar deviasi intensitas
    h = computeHistogram(img);
    totalPiksel = sum(h);
    nilai = 0:255;

    nilaiMin = min(img(:));      
    nilaiMax = max(img(:));

    nilaiMean = sum(nilai .* h) / totalPiksel;
    varians = sum(((nilai - nilaiMean).^2) .* h) / totalPiksel;
    nilaiStd = sqrt(varians);
end
