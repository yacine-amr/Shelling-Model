clear 
clc
% initialization:
L = 50
n_iterations = 1000
empty_ratio = 0.1 
similarity_threshold = 0.65
% L = 50 and empty_ratio = 0.1, so the plot looks good and the segregation is clear 
% the user can try different combinations for the initial parameters even L>100
S = randi([0  1],L, L)
S(S ==0) =-1
empty_index = randi([L*L], 1, round(L*L*empty_ratio));
S(empty_index) = 0;
% we have a matrix of (0, 1,-1) and 0 for empty 

% The process is the folowing:
% 1. pick an agent
% 2. get his neighbours indexes
% 3. Check if satisfied
% 4. Not satisfied ?
% 5. move agent to empty place and replace agent with 0
% 6. exit the loop when all satisfied
% 7. plot a sparsity pattern of matrix

for i=2:1:n_iterations   
    n_changes = 0; 
    for j = 1:1:L*L 
        % pick an agent
        [x,y] = ind2sub([L, L],j);
        % make sure we don't pick an empty agent!
        if S(x,y) == 0
            continue;
        end
        current_agent = S(x,y);
        count_similar = 0;
        count_different = 0;
        % get all neighbours indexes:
        indexes = [];
        % Boundary conditions: 
        if x>1
            indexes = [ indexes sub2ind([L, L],x-1, y)];
            if y>1
                indexes =[ indexes sub2ind([L, L],x-1, y-1)];
            end
            if y<L
                indexes =[ indexes sub2ind([L, L],x-1, y+1)];
            end
        end
        if x<L
            indexes =[ indexes sub2ind([L, L],x+1, y)];
            if y>1
                indexes =[ indexes sub2ind([L, L],x+1, y-1)];
            end
            if y<L
                indexes =[ indexes sub2ind([L, L],x+1, y+1)];
            end
        end 
        if y<L
            indexes =[ indexes sub2ind([L, L],x, y+1)];
        end
        
        if y<L && y>1
            indexes =[ indexes sub2ind([L, L],x, y-1)];
        end

        % Check if satisfied:
        for id=1:1:length(indexes)
            if current_agent == S(indexes(id))
                count_similar = count_similar+1;
            elseif  current_agent == -S(indexes(id))
                count_different = count_different+1;
            end
        end
        if count_similar+count_similar == 0
            check = true;
        else
            check = (count_similar/(count_similar+count_different)) < similarity_threshold;
        end

        % Not satisfied ?
        if check~= 0
            % move agent to empty place and replace agent with 0
            current_agent = S(x,y);
            empty_spot = find(S==0);
            index_to_move = randi([1 length(empty_spot)],1);
            S(empty_spot(index_to_move)) = current_agent;
            S(x,y) = 0;
            n_changes = n_changes+1;
        end 
    end

    % Ploting:
    figure(1);
    spy(S(:,:) == -1,'r');
    hold on
    spy(S(:,:) == 1, 'b')
    hold off
    pause(0.01);
    agent_matrix(:,:,i) = S(:,:);
    fprintf('Iteration %d, changed %d \n',i,n_changes);
    if n_changes == 0
        fprintf('System stabilized\n');
        break;
    end
    % This is to get the frames for the video:
    %movievector (i)= getframe()
end

% This section is commented to not keep exporting videos while the user is trying the model
% movievector = movievector(2:end)
% mywriter = VideoWriter('Shelling')
% open(mywriter);
% writeVideo(mywriter,movievector);
% close(mywriter);
