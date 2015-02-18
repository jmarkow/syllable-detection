function SNR=fiberdata_eval_filter(FILTERED_DATA,TARGET,varargin)
%
%
%

% smooth data

thresholds=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'thresholds'
			thresholds=varargin{i+1};
	end
end

[nsamples,ntrials]=size(FILTERED_DATA);

NONTARGET=setdiff(1:nsamples,TARGET);

hitdata=FILTERED_DATA(TARGET,:);
missdata=FILTERED_DATA(NONTARGET,:);

SNR=mean(hitdata(:))./mean(missdata(:));


