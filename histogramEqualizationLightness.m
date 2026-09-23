function hasil = histogramEqualizationLightness(img)
%perataan histogram (histogram equalization lightnessnya)
%img   : citra grayscale (2D) atau RGB (3D), uint8
%hasil : citra hasil equalization (uint8)

if size(img,3) == 3
    labImg = rgb2lab(img);
    L = labImg(:,:,1);                    

    Lskala = uint8(round(L / 100 * 255));  %rentang lab itu 0 - 100
    LhasilSkala = equalizeGray(Lskala);

    labImg(:,:,1) = double(LhasilSkala) / 255 * 100;  %convert lagi ke ke 0-100
    hasil = im2uint8(lab2rgb(labImg)); 
    return;
end

hasil = equalizeGray(img);
end

function hasil = equalizeGray(img)
%equalization murni untuk 2D
h = histogram(img);       
totalPiksel = numel(img);

pdf = h / totalPiksel;
cdf = cumsum(pdf); %cdf(k) = P(intensitas <= k-1) cumulatif distribution function

lut = uint8(round(255 * cdf));   %lookup table: lut(r+1)
hasil = lut(double(img) + 1);    %mapping
end

function hasil = equalizeHistogramRGB(img)
hasil = zeros(size(img), 'uint8');
for channelIndex = 1:3
    hasil(:,:,channelIndex) = equalizeGray(img(:,:,channelIndex));
end
end