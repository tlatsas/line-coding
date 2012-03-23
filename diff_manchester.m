function diff_manchester( bitstream )
    %DIFF_MANCHESTER Differential Manchester encoding
    %   sample data:
    %       d = [ 0 1 0 0 1 1 0 0 0 1 1 ]
    %   usage:
    %       diff_manchester(d)
    %   author:
    %       Anastasios Latsas

    % pulse height
    pulse = 0.85;
    % assume high->low level for pulse before given data
    current_level = -pulse;

    for bit = 1:length(bitstream)
        % set bit time
        bt = bit-1:0.001:bit;

        if current_level < 0
            % low -> high
            y = (bt<bit) * pulse - 2 * pulse * (bt < bit - 0.5);
        else
            % high -> low
            y = -(bt<bit) * pulse + 2 * pulse * (bt < bit - 0.5);
        end

        % in diff manchester each bit change pulse levels
        current_level = -current_level;

        try
            if bitstream(bit+1) == 0
                % zero forces a change at pulse start
                current_level = - current_level;
            end
        catch e
            % do nothing; assume next bit is 1 which does not
            % chage the beggining of the next pulse level
        end

        % replace last zero with next level start
        y(end) = current_level;

        % draw pulse and bit label
        plot(bt, y, 'LineWidth', 2);
        text(bit-0.5, pulse+0.5, num2str(bitstream(bit)), ...
            'FontWeight', 'bold')
        hold on;
    end
    % draw grids
    grid on;
    axis([0 length(bitstream) -pulse-1 pulse+1]);
    set(gca,'YTick', [-pulse 0 pulse])
    set(gca,'XTick', 1:length(bitstream))
    set(gca,'XTickLabel', '')
    title('Differential Manchester Encoding')
end
