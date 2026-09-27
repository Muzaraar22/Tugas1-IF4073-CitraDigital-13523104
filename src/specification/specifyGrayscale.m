function result = specifyGrayscale(img, ref)
%histogram specification/matching, grayscale 2D

%img : citra sumber yang mau diubah (uint8)
%ref : citra referensi (uint8)
%hasil : citra sumber, histogramnya sudah diubah

hImg = computeHistogram(img);
hRef = computeHistogram(ref);

cdfImg = cumsum(hImg / numel(img));
cdfRef = cumsum(hRef / numel(ref));

lut = zeros(1, 256, 'uint8');
for r = 1:256
    %cari index CDF ref yang paling dekat dari CDF Sumber cdfImg(r)
    [~, idx] = min(abs(cdfRef - cdfImg(r)));
    lut(r) = idx - 1;  %idx (1-256) -> intensitas (0-255)
end

result = lut(double(img) + 1);   %match intensitas ke lookup table
end
