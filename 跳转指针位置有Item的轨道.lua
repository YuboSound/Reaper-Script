-- 在当前光标位置处查找有Item的轨道并跳转，同时跳过第一轨
function main()
    -- 获取当前播放光标位置
    local cursor_pos = reaper.GetCursorPosition()
    
    -- 获取工程中的轨道数量
    local track_count = reaper.CountTracks(0)
    
    if track_count <= 1 then -- 如果只有一轨或没有轨道，直接返回
        reaper.ShowMessageBox("工程中没有足够的轨道", "提示", 0)
        return
    end
    
    local found_track = nil
    
    -- 遍历所有轨道（从第二轨开始，索引1），跳过第一轨
    for i = 1, track_count - 1 do -- 修改了循环起始索引，跳过第一轨（索引0）
        local track = reaper.GetTrack(0, i)
        
        -- 检查轨道在光标位置是否有Item
        local item_count = reaper.CountTrackMediaItems(track)
        
        for j = 0, item_count - 1 do
            local item = reaper.GetTrackMediaItem(track, j)
            local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            local item_end = item_start + item_length
            
            -- 检查光标是否在Item的时间范围内
            if cursor_pos >= item_start and cursor_pos <= item_end then
                found_track = track
                break
            end
        end
        
        if found_track then
            break
        end
    end
    
    if found_track then
        -- 取消所有轨道选择
        reaper.Main_OnCommand(40297, 0)  -- 取消选择所有轨道
        
        -- 选中找到的轨道
        reaper.SetTrackSelected(found_track, true)
        
        -- 将选中轨道滚动到视图中心
        reaper.SetMixerScroll(found_track)
        
        -- 滚动到选中的轨道（确保在视图中可见）
        reaper.Main_OnCommand(40913, 0)  -- 视图: 将选中轨道滚动到视图中
        
        -- 可选：将时间轴视图也滚动到光标位置
        reaper.Main_OnCommand(40131, 0)  -- 视图: 将编辑光标滚动到视图中
        
        reaper.Undo_OnStateChange("跳转到光标处有Item的轨道（跳过第一轨）")
    else
        reaper.ShowMessageBox("在光标位置没有找到包含Item的轨道（已跳过第一轨）", "提示", 0)
    end
end

-- 运行脚本
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
