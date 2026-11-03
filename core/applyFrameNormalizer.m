function Y = applyFrameNormalizer(X,nrm)
Y=(double(X)-nrm.Mean)./nrm.Std;
Y=single(Y);
end
