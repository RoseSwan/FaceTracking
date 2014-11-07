function idx = clean_keypoints(X)

% construct distance matrix, find entries that are equal
N = size(X,2);
[i,j] = ind2sub([N,N], find(~squareform(pdist(X(1:3,:)'))));
idx = setdiff(1:N,i(i<j));