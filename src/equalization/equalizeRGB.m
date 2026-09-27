function result = equalizeRGB(img)
result = zeros(size(img), 'uint8');
for channelIndex = 1:3
    result(:,:,channelIndex) = equalizeGrayscale(img(:,:,channelIndex));
end
end
