function C = clean_corresp(X,Y,C)
% Toss out redundant correspondences

for i = unique(C)'
    if nnz(C==i) > 1
        idx = find(C==i);
        min_idx = 1;
        min_val = norm(X(C(idx(1)),:)-Y(idx(1),:));
        for j = 2:length(idx)
            if norm(X(C(idx(j)),:)-Y(idx(j),:)) < min_val
                min_val = norm(X(C(idx(j)),:)-Y(idx(j),:)) < min_val;
                min_idx = j;
            end
        end
        C(idx((1:length(idx))~=min_idx)) = 0;
    end
end