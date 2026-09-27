function plotHistogram(img, judul)
% menampilkan citra + histogramnya

if nargin < 2, judul = ''; end

if size(img,3) == 3 %ada 3 chanel/rgb
    figure('Name', judul);
    subplot(2,3,1); imshow(img); title(['Citra ' judul]);
    subplot(2,3,2); h = computeHistogram(rgb2gray(img));
    bar(0:255, h, 'w'); title('Histogram Grayscale'); xlabel('Intensitas'); ylabel('Jumlah Piksel');

    ch = {'R','G','B'};
    warnaBar  = {'r','g','b'};
    for k = 1:3
        h = computeHistogram(img(:,:,k));
        subplot(2,3,k+3);
        bar(0:255, h, warnaBar{k});
        title(['Histogram Channel/Kanal ' ch{k}]);
        xlabel('Intensitas'); ylabel('Jumlah Piksel');
    end
else %gray scale
    figure('Name', judul);
    subplot(1,2,1); imshow(img); title(['Citra ' judul]);
    subplot(1,2,2);
    h = computeHistogram(img);
    bar(0:255, h, 'w');
    title('Histogram Grayscale');
    xlabel('Intensitas'); ylabel('Jumlah Piksel');
end
end
