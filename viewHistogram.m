function viewHistogram(img, judul)
% menampilkan citra + histogramnya

if nargin < 2, judul = ''; end

if size(img,3) == 3 %ada 3 chanel/rgb
    figure('Name', judul);
    subplot(2,2,1); imshow(img); title(['Citra ' judul]);

    ch = {'R','G','B'};
    warnaBar  = {'r','g','b'};
    for k = 1:3
        h = histogram(img(:,:,k));
        subplot(2,2,k+1);
        bar(0:255, h, warnaBar{k});
        title(['Histogram Channel/Kanal ' ch{k}]);
        xlabel('Intensitas'); ylabel('Jumlah Piksel');
    end
else %gray scale
    figure('Name', judul);
    subplot(1,2,1); imshow(img); title(['Citra ' judul]);
    subplot(1,2,2);
    h = histogram(img);
    bar(0:255, h);
    title('Histogram');
    xlabel('Intensitas'); ylabel('Jumlah Piksel');
end
end