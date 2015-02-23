function [NEW_FILTER,HITS]=fiberdata_load(AUDIO,TARGET_SOUND,FS,varargin)
%
%
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

if ~isa(TARGET_SOUND,'double')
	TARGET_SOUND=double(TARGET_SOUND);
end

% smooth data

threshold=.15; % xcorr threshold for hits 
range=[];
trim_per=50;
marker_jitter=300;
marker=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'marker'
			marker=varargin{i+1};
		case 'trim_per'
			trim_per=varargin{i+1};
		case 'marker_jitter'
			marker_jitter=varargin{i+1};
	end
end

[nsamples,ntrials]=size(AUDIO);
template=flipud(zscore(TARGET_SOUND(:)));

norm_factor=template'*template;
template=template/norm_factor;

len=length(template);

disp('Creating target vector...');

score=filter(template,1,zscore(AUDIO));
HITS=[];

for i=1:ntrials

	[vals,locs]=findpeaks(score(:,i),'minpeakheight',threshold,'minpeakdistance',round(.1*FS));

	if ~isempty(marker)
		flag1=locs<marker-marker_jitter;
		flag2=locs>marker+marker_jitter;
		to_del=flag1|flag2;
		vals(to_del)=[];
		locs(to_del)=[];
	end

	if isempty(vals)
		continue;
	end

	[sortvals,sortidx]=sort(vals(:),1,'descend');

	startpoint=round(locs(sortidx(1))-(len-1));
	stoppoint=startpoint+(len-1);

	if startpoint>1 & stoppoint<length(score)
		HITS=[HITS AUDIO(startpoint:stoppoint,i)];
	end

end

NEW_FILTER=flipud(trimmean(HITS,trim_per,'round',2));
