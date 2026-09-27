function kernel = readKernelGrid(editFields)

ukuran = size(editFields);
kernel = zeros(ukuran);
for i = 1:ukuran(1)
    for j = 1:ukuran(2)
        kernel(i,j) = editFields(i,j).Value;
    end
end
end
