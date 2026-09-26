function hasil = histogramEqualizationLightness(img)
%perataan histogram (histogram equalization lightnessnya)
%img   : citra grayscale (2D) atau RGB (3D), uint8
%hasil : citra hasil equalization (uint8)

if size(img,3) == 3
    labImg = rgb2lab(img);
    Lskala = getLightnessChannel(img);
    LhasilSkala = equalizeGray(Lskala);

    labImg(:,:,1) = double(LhasilSkala) / 255 * 100;  %convert lagi ke ke 0-100
    hasil = im2uint8(lab2rgb(labImg)); 
    return;
end

hasil = equalizeGray(img);
end