function [CONF_MATRIX THRESHOLDS]=sylldet_eval_filter_roc(FILTERED_DATA,TARGET,varargin)
%
%
%

% smooth data

THRESHOLDS=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'THRESHOLDS'
			THRESHOLDS=varargin{i+1};
	end
end

THRESHOLDS=linspace(min(FILTERED_DATA(:)),max(FILTERED_DATA(:)),200);
nthresh=length(THRESHOLDS);

[nsamples,ntrials]=size(FILTERED_DATA);

TARGET=TARGET(1):TARGET(2);
nontarget=setdiff(1:nsamples,TARGET);

tp=zeros(1,nthresh);
tn=zeros(1,nthresh);

fp=zeros(1,nthresh);
fn=zeros(1,nthresh);

CONF_MATRIX=zeros(2,2,length(THRESHOLDS));

for i=1:length(THRESHOLDS)

	idx=FILTERED_DATA>THRESHOLDS(i);

	[~,trials]=find(idx(TARGET,:));

	tp(i)=length(unique(trials));
	fn(i)=ntrials-tp(i);

	[~,trials]=find(idx(nontarget,:));

	fp(i)=length(unique(trials));
	tn(i)=ntrials-fp(i);

	CONF_MATRIX(1:2,1:2,i)=[ tp(i) fn(i) ; fp(i) tn(i) ]; 
end

% optimal point, closest in Euclidean distance to [0,1]


figure();plot(fp./ntrials,tp./ntrials);


