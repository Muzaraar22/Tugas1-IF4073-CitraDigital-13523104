function editFields = buatKernel(parent, ukuran)
% buatKernel - bikin grid kotak input NxN di GUI

% parent     : handle container tempat grid ditaruh (misal
%              app.UIFigure atau sebuah uipanel di App Designer)
% ukuran     : skalar ganjil
% editFields : array handle uieditfield ukuran NxN, dipakai nanti
%              buat baca nilai yang diketik user (lihat bacaKernel.m)

layout = uigridlayout(parent, [ukuran ukuran]);
layout.RowSpacing = 2;
layout.ColumnSpacing = 2;

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