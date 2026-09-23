function hasil = histogramSpecification(img, ref)
%cocokkan histogram img ke histogram ref

%img, ref : citra grayscale (2D) atau RGB (3D), uint8 
%hasil   : citra img yg sudah di matching

if size(img,3) == 3
    Limg = getLightnessChannel(img);
    Lref = getLightnessChannel(ref);           % ref RGB atau gray, sama-sama aman

    Lhasil = specifyGray(Limg, Lref);

    labImg = rgb2lab(img);
    labImg(:,:,1) = double(Lhasil) / 255 * 100;
    hasil = im2uint8(lab2rgb(labImg));
    return;
end

hasil = specifyGray(img, ref);
end