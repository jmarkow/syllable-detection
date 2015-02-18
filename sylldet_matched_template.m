function [NEW_FILTER,HITS]=fiberdata_load(AUDIO,TARGET_SOUND,FS,varargin)
%
%
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end



% smooth data

freq_range=[200 7e3]; % bandpass before collecting template
threshold=.1; % xcorr threshold for hits 
range=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'freq_range'
			freq_range=varargin{i+1};
		case 'range'
			range=varargin{i+1};
	end
end

[nsamples,ntrials]=size(AUDIO);

HITS=[];

AUDIO=zscore(AUDIO);
TARGET_SOUND=zscore(TARGET_SOUND);

template=flipud(TARGET_SOUND(:));
norm_factor=template'*template;
len=length(template);

for i=1:ntrials

	score=conv(AUDIO(:,i),template,'same');
	score=score/norm_factor;

	[vals,locs]=findpeaks(score,'minpeakheight',threshold,'minpeakdistance',round(.1*FS));

	if ~isempty(range)
		flag1=locs<range(1);
		flag2=locs>range(2);
		to_del=flag1|flag2;
		vals(to_del)=[];
		locs(to_del)=[];
	end

	if isempty(vals)
		continue;
	end

	[sortvals,sortidx]=sort(vals(:),1,'descend');

	startpoint=round(locs(sortidx(1))-len/2);
	stoppoint=startpoint+len-1;

	if startpoint>1 & stoppoint<length(score)
		HITS=[HITS AUDIO(startpoint:stoppoint,i)];
	end

end

NEW_FILTER=flipud(trimmean(HITS,50,'round',2));
