function sylldet_coef_filterbank_export(DIR,NAME,FILTERBANK,IN_BAND,OUT_BAND)
%
%
%


% write FIR coefficients to a FILE


nfilters=length(FILTERBANK);
filtermat=zeros(length(FILTERBANK(1).Numerator),nfilters);

for i=1:nfilters
	filtermat(:,i)=FILTERBANK(i).Numerator;
end

% save filters to separate files

for i=1:length(IN_BAND)
	infiltermat=filtermat(:,IN_BAND(i));
	save(fullfile(DIR,['infilter' num2str(i) '.txt']),'infiltermat','-ascii');
end

for i=1:length(OUT_BAND)
	outfiltermat=filtermat(:,OUT_BAND(i));
	save(fullfile(DIR,['outfilter' num2str(i) '.txt']),'outfiltermat','-ascii');
end


