function h = histogram(img)

h = zeros(1, 256);
[tinggi, lebar] = size(img);

for i = 1:tinggi
    for j = 1:lebar
        nilai = double(img(i,j));
        h(nilai + 1) = h(nilai + 1) + 1;
    end
end
end