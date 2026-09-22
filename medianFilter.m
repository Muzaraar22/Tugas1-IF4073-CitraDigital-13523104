function hasil = medianFilter(img, ukuranWindow)
%img          : citra grayscale (2D) atau RGB (3D), uint8
%ukuranWindow : ganjil
%hasil        : citra (uint8)

if size(img,3) == 3
    R = medianFilter(img(:,:,1), ukuranWindow);
    G = medianFilter(img(:,:,2), ukuranWindow);
    B = medianFilter(img(:,:,3), ukuranWindow);
    hasil = cat(3, R, G, B);
    return;
end

if mod(ukuranWindow, 2) == 0
    error('Ukuran harus ganjil');
end

img = double(img);
[tinggi, lebar] = size(img);
pad = (ukuranWindow - 1) / 2;

%padding replicate
imgPad = zeros(tinggi + 2*pad, lebar + 2*pad);
imgPad(pad+1:pad+tinggi, pad+1:pad+lebar) = img;
imgPad(1:pad, pad+1:pad+lebar)            = repmat(img(1,:), pad, 1);
imgPad(pad+tinggi+1:end, pad+1:pad+lebar) = repmat(img(end,:), pad, 1);
imgPad(:, 1:pad)                          = repmat(imgPad(:, pad+1), 1, pad);
imgPad(:, pad+lebar+1:end)                = repmat(imgPad(:, pad+lebar), 1, pad);

hasil = zeros(tinggi, lebar);

for i = 1:tinggi
    for j = 1:lebar
        region    = imgPad(i:i+ukuranWindow-1, j:j+ukuranWindow-1);
        nilaiUrut = sort(region(:));                          %sort nilai dalam window
        hasil(i,j) = nilaiUrut(ceil(numel(nilaiUrut)/2));     
    end
end

hasil = uint8(round(hasil));
end