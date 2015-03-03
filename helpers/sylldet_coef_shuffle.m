function shuf_coeffs=coef_shuffle(coeffs)
%
% shuffles coefficients per TDT FIR format

% vector must be even

if mod(numel(coeffs),2)~=0
    error('Number of coefficients must be even!');
end

shuf_coeffs=zeros(size(coeffs));
ncoeffs=numel(coeffs);

counter=1;
for i=1:2:ncoeffs
    shuf_coeffs(i)=coeffs(counter);
    counter=counter+1;
end

counter=0;
for i=2:2:ncoeffs
    shuf_coeffs(i)=coeffs(ncoeffs/2+counter);
    counter=counter+1;
end