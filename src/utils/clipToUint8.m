function result = clipToUint8(result)
% result : citra 2D/3D bertipe double (atau numerik lain)
% mengembalikan uint8 dengan nilai dibatasi ke rentang 0-255

%clip
result(result < 0)   = 0;
result(result > 255) = 255;
result = uint8(round(result));
end
