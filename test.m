smoothing = [1 1 1; 1 2 1; 1 1 1] / 10;

img = konvolusi(imgGray, smoothing);
imgLib = imfilter(imgGray, smoothing, 'replicate');   % 'replicate' disamakan buat dibanding

figure;
subplot(1,3,1); imshow(imgGray);      title('Asli');
subplot(1,3,2); imshow(img); title('Konvolusi Sendiri');
subplot(1,3,3); imshow(imgLib); title('imfilter (pembanding)');

selisih = double(img) - double(imgLib);
fprintf('Selisih maksimum: %d\n', max(abs(selisih(:))));