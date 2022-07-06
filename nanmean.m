function ave = nanmean(X)
    ave = sum(X(~isnan(X)))/nnz(~isnan(X));
end
