function Lskala = getLightnessChannel(img)
%mengambil channel Lightness (Lab) dan diskalakan ke 0-255
%kalau 2D/grayscale lgsng return

%Lskala : citra 2D uint8, rentang 0-255

if size(img,3) == 3
    lab = rgb2lab(img);
    L = lab(:,:,1);   %rentang asli Lab: 0-100
    Lskala = uint8(round(L / 100 * 255));
else
    Lskala = img;
end
end