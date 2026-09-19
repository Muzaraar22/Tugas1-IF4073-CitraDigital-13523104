img = imread('C:\Users\Muzaraar\Documents\Kuliah\Kelas_Kuliah\Semester_7\Citra Digital\Tugas1-IF4073-CitraDigital-13523104\citra_test_images\1. Histogram Citra\image_01.png');

disp(class(img));   
disp(size(img));   

if size(img,3) == 3
    imgGray = rgb2gray(img);
else
    imgGray = img;
end

figure;
imshow(imgGray);
title('Citra Grayscale');


myHist = Histogram(imgGray);
libHist = imhist(imgGray);


% bandingkan visual
figure;
subplot(1,2,1);
bar(0:255, myHist);
title('Histogram - Sendiri');
xlabel('Intensitas'); ylabel('Jumlah Piksel');

subplot(1,2,2);
bar(0:255, libHist);
title('Histogram - imhist');
xlabel('Intensitas'); ylabel('Jumlah Piksel');

% Bandingkan secara angka
cocok = isequal(myHist(:), libHist(:));
fprintf('identik?%d\n', cocok);