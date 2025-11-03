-- 增强版：批量创建区域并命名
function create_regions_for_selected_items_advanced()
    local item_count = reaper.CountSelectedMediaItems(0)
    
    if item_count == 0 then
        reaper.ShowMessageBox("请先选择一些Item", "提示", 0)
        return
    end
    
    -- 获取用户输入：基础名称和起始编号
    local retval, user_inputs = reaper.GetUserInputs("批量命名区域", 2, "基础名称,起始编号:", "Region,1")
    if not retval then return end -- 用户取消了输入
    
    local base_name, start_num_str = user_inputs:match("([^,]+),([^,]+)")
    base_name = base_name:gsub("%s+$", "") -- 移除尾部空格
    
    -- 解析起始编号
    local start_num = tonumber(start_num_str) or 1
    
    -- 获取当前项目
    local project = 0
    
    -- 是否覆盖现有区域（可选功能）
    local clear_existing = reaper.ShowMessageBox("是否清除工程中所有现有区域？", "区域管理", 4) -- 4 = Yes/No
    
    if clear_existing == 6 then -- 6 = Yes
        reaper.Main_OnCommand(40172, 0) -- 删除所有区域
    end
    
    -- 遍历所有选中的Item
    for i = 0, item_count - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            -- 获取Item的位置和长度
            local position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            
            -- 计算结束位置
            local end_position = position + length
            
            -- 生成序号后缀（两位数格式）
            local current_num = start_num + i
            local suffix = string.format("_%02d", current_num)
            
            -- 组合完整的区域名称
            local region_name = base_name .. suffix
            
            -- 添加区域
            local region_index = reaper.AddProjectMarker2(project, true, position, end_position, region_name, -1, 0)
            
            -- 可选：将区域颜色设置为与Item相同
            local item_color = reaper.GetMediaItemInfo_Value(item, "I_CUSTOMCOLOR")
            if item_color and item_color ~= 0 then
                reaper.SetProjectMarker4(project, region_index, true, position, end_position, region_name, item_color, 0)
            end
        end
    end
    
    -- 更新时间线显示
    reaper.UpdateTimeline()
    
    -- 显示完成消息
    reaper.ShowMessageBox(string.format("已为 %d 个Item创建区域\n起始编号: %d", item_count, start_num), "完成", 0)
end

-- 运行主函数
reaper.defer(create_regions_for_selected_items_advanced)
