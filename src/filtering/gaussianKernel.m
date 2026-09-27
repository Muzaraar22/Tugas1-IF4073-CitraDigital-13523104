function kernel = gaussianKernel(ukuran, sigma)

pusat = (ukuran + 1) / 2;
kernel = zeros(ukuran, ukuran);
for i = 1:ukuran
    for j = 1:ukuran
        x = i - pusat;
        y = j - pusat;
        kernel(i,j) = exp(-(x^2 + y^2) / (2*sigma^2));
    end
end
kernel = kernel / sum(kernel(:));
end
