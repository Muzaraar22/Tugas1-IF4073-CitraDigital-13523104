function result = convolution(img, kernel)
%kernel : ganjil x ganjil, dinormalisasikan dulu baru panggil fungsi ini
%hasil  : citra (uint8), ukuran sama dengan input

if size(img,3) == 3
    R = convolution(img(:,:,1), kernel); %layer depth ke 1
    G = convolution(img(:,:,2), kernel);
    B = convolution(img(:,:,3), kernel);
    result = cat(3, R, G, B);
    return;
end

img = double(img);
[tinggi, lebar] = size(img);
[kh, kw] = size(kernel);

if mod(kh,2) == 0 || mod(kw,2) == 0
    error('Ukuran kernel harus ganjil:');
end

padH = (kh - 1) / 2;
padW = (kw - 1) / 2;

%padding replikasi piksel
imgPad = zeros(tinggi + 2*padH, lebar + 2*padW);
imgPad(padH+1:padH+tinggi, padW+1:padW+lebar) = img;

imgPad(1:padH, padW+1:padW+lebar) = repmat(img(1,:), padH, 1);   %atas
imgPad(padH+tinggi+1:end, padW+1:padW+lebar) = repmat(img(end,:), padH, 1); %bawah
imgPad(:, 1:padW) = repmat(imgPad(:, padW+1), 1, padW);       %kiri (include sudut)
imgPad(:, padW+lebar+1:end) = repmat(imgPad(:, padW+lebar), 1, padW);   %kanan (include sudut)

result = zeros(tinggi, lebar);

for i = 1:tinggi
    for j = 1:lebar
        region = imgPad(i:i+kh-1, j:j+kw-1);      %window seukuran kernel
        result(i,j) = sum(sum(region .* kernel));   %konvolusi
    end
end

%clip
result(result < 0)   = 0;
result(result > 255) = 255;
result = uint8(round(result));
end
