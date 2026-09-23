function hasil = histogramEqualizationRGB(img)
hasil = zeros(size(img), 'uint8');
for channelIndex = 1:3
    hasil(:,:,channelIndex) = equalizeGray(img(:,:,channelIndex));
end
end