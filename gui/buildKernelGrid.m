function editFields = buildKernelGrid(parent, ukuran)
% buatKernel - bikin grid kotak input NxN di GUI

% parent     : handle container tempat grid ditaruh (misal
%              app.UIFigure atau sebuah uipanel di App Designer)
% ukuran     : skalar ganjil
% editFields : array handle uieditfield ukuran NxN, dipakai nanti
%              buat baca nilai yang diketik user (lihat readKernelGrid.m)

% Ukuran baris/kolom memakai '1x' (flex), bukan pixel tetap, supaya grid ikut
% mengisi ruang panel apa pun ukurannya. Ukuran pixel tetap akan membuat kotak
% input menyusut kalau ruang tersedia berubah.
layout = uigridlayout(parent, [ukuran ukuran]);
layout.RowHeight = repmat({'1x'}, 1, ukuran);
layout.ColumnWidth = repmat({'1x'}, 1, ukuran);
layout.RowSpacing = 1;
layout.ColumnSpacing = 1;
layout.BackgroundColor = 'w';

editFields = gobjects(ukuran, ukuran);

for i = 1:ukuran
    for j = 1:ukuran
        ef = uieditfield(layout, 'numeric');
        ef.Layout.Row = i;
        ef.Layout.Column = j;
        ef.Value = 0;          % default awal, user tinggal timpa
        editFields(i,j) = ef;
    end
end
end
