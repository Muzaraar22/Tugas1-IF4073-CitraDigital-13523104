function counts = computeHistogram(image)

counts = zeros(1, 256);
[height, width] = size(image);

for i = 1:height
    for j = 1:width
        level = double(image(i,j));
        counts(level + 1) = counts(level + 1) + 1;
    end
end
end
