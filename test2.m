test = medianFilter(imgGray, 3);
lib = medfilt2(imgGray, [3 3]);

figure;
subplot(1,3,1); imshow(imgGray);      title('ori');
subplot(1,3,2); imshow(test); title('Median test');
subplot(1,3,3); imshow(lib); title('medfilt2');

medTest = test(2:end-1, 2:end-1);
medLib = lib(2:end-1, 2:end-1);
selisih = double(medTest) - double(medLib);
fprintf('Selisih max: %d\n', max(abs(selisih(:))));