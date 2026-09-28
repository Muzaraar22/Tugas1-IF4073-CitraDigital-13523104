function appendRecordCsv(csvPath, header, row)
% appendRecordCsv - menambah satu baris ke berkas rekap CSV.
%
%   csvPath : path lengkap file CSV tujuan (misalnya 'out/rekapan.csv')
%   header  : cell array nama kolom, hanya dipakai bila file belum ada
%   row     : cell array nilai baris baru, urutannya harus sama dengan header
%
%   Dipakai bersama oleh GUI (tombol "Simpan Rekapan") dan oleh script batch,
%   supaya urutan kolom tidak pernah berbeda antara keduanya.

validateattributes(csvPath, {'char', 'string'}, {'nonempty'}, ...
    'appendRecordCsv', 'csvPath');

if ~iscell(header) || ~iscell(row)
    error('appendRecordCsv:argBukanCell', 'header dan row harus berupa cell array.');
end

if numel(row) ~= numel(header)
    error('appendRecordCsv:jumlahKolomTidakCocok', ...
        'Jumlah nilai baris (%d) tidak sama dengan jumlah kolom (%d).', ...
        numel(row), numel(header));
end

folder = fileparts(csvPath);
if ~isempty(folder) && ~isfolder(folder)
    mkdir(folder);
end

isNew = ~isfile(csvPath);

fid = fopen(csvPath, 'a', 'n', 'UTF-8');
if fid < 0
    error('appendRecordCsv:tidakBisaDitulis', ...
        'Tidak bisa menulis ke berkas: %s', csvPath);
end

cleanupFid = onCleanup(@() fclose(fid));

if isNew
    fwrite(fid, strjoin(csvEscape(header), ','), 'char');
    fwrite(fid, newlineString(), 'char');
end

fwrite(fid, strjoin(csvEscape(row), ','), 'char');
fwrite(fid, newlineString(), 'char');
end

% ---------------------------------------------------------------------------
function out = csvEscape(cellValues)
% csvEscape - beri tanda kutip ganda pada nilai yang mengandung koma, tanda
% kutip, atau baris baru, sesuai kaidah RFC 4180.
out = cell(size(cellValues));
for k = 1:numel(cellValues)
    v = cellValues{k};
    if isnumeric(v)
        v = num2str(v);
    elseif islogical(v)
        v = char(string(v));
    elseif (isstring(v) && numel(v) ~= 1)
        v = '';
    end
    v = char(v);

    butuhKutip = contains(v, ',') || contains(v, '"') || ...
        contains(v, newline);
    if butuhKutip
        v = ['"' strrep(v, '"', '""') '"'];
    end
    out{k} = v;
end
end

% ---------------------------------------------------------------------------
function nl = newlineString()
% newlineString - baris baru LF supaya keluaran konsisten di semua OS
% (mengacu pada .gitattributes proyek yang memakai eol=lf).
nl = newline;
end
