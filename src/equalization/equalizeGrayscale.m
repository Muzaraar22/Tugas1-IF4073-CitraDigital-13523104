function result = equalizeGrayscale(img)
%equalization murni untuk 2D
h = computeHistogram(img);
totalPiksel = numel(img);

pdf = h / totalPiksel;
cdf = cumsum(pdf); %cdf(k) = P(intensitas <= k-1) cumulatif distribution function

lut = uint8(round(255 * cdf));   %lookup table: lut(r+1)
result = lut(double(img) + 1);    %mapping
end
