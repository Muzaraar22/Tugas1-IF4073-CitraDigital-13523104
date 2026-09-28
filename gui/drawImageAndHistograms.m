function drawImageAndHistograms(axImage, axGray, axChannels, img, judul)
% drawImageAndHistograms - menggambar citra beserta histogramnya ke axes yang diberikan
%
% axImage     : axes untuk menampung citra
% axGray      : axes untuk menampung histogram grayscale
% axChannels  : array 1x3 axes untuk histogram kanal R, G, B
%               (kirim [] kalau citra grayscale)
% img         : citra grayscale (2D) atau RGB (3D), uint8
% judul       : judul untuk citra
%
% Dipakai bersama oleh plotHistogram (yang membuat figure sendiri) dan oleh
% GUI (yang menggambar langsung ke axes milik app). Seluruh histogram tetap
% dihitung dengan computeHistogram, bukan imhist.

if size(img,3) == 3 %ada 3 chanel/rgb
    imshow(img, 'Parent', axImage);
    title(axImage, ['Citra ' judul]);

    h = computeHistogram(rgb2gray(img));
    bar(axGray, 0:255, h, 'w');
    title(axGray, 'Histogram Grayscale');
    xlabel(axGray, 'Intensitas'); ylabel(axGray, 'Jumlah Piksel');

    ch = {'R','G','B'};
    warnaBar  = {'r','g','b'};
    for k = 1:3
        h = computeHistogram(img(:,:,k));
        bar(axChannels(k), 0:255, h, warnaBar{k});
        title(axChannels(k), ['Histogram Channel/Kanal ' ch{k}]);
        xlabel(axChannels(k), 'Intensitas'); ylabel(axChannels(k), 'Jumlah Piksel');
    end
else %gray scale
    imshow(img, 'Parent', axImage);
    title(axImage, ['Citra ' judul]);

    h = computeHistogram(img);
    bar(axGray, 0:255, h, 'w');
    title(axGray, 'Histogram Grayscale');
    xlabel(axGray, 'Intensitas'); ylabel(axGray, 'Jumlah Piksel');
end
end
