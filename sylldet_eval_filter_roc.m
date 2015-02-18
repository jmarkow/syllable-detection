function fiberdata_eval_filter(FILTERED_DATA,TARGET,varargin)
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

thresholds=linspace(min(FILTERED_DATA(:)),max(FILTERED_DATA(:)),200);
nthresh=length(thresholds);

[nsamples,ntrials]=size(FILTERED_DATA);

NONTARGET=setdiff(1:nsamples,TARGET);

tp=zeros(1,nthresh);
tn=zeros(1,nthresh);

fp=zeros(1,nthresh);
fn=zeros(1,nthresh);


for i=1:length(thresholds)

	idx=FILTERED_DATA>thresholds(i);

	[~,trials]=find(idx(TARGET,:));

	tp(i)=length(unique(trials));
	fn(i)=ntrials-tp(i);

	[~,trials]=find(idx(NONTARGET,:));

	fp(i)=length(unique(trials));
	tn(i)=ntrials-fp(i);

end

% optimal point, closest in Euclidean distance to [0,1]

figure();plot(fp./ntrials,tp./ntrials);


