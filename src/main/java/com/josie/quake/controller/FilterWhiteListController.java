package com.josie.quake.controller;

import com.josie.quake.commons.Constant;
import com.josie.quake.commons.utils.ErrorInfo;
import com.josie.quake.commons.utils.RegexUtils;
import com.josie.quake.commons.utils.ResponseUtils;
import com.josie.quake.model.FilterRule;
import com.josie.quake.model.FilterWhiteList;
import com.josie.quake.model.User;
import com.josie.quake.service.FilterWhiteListService;
import com.josie.quake.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Josie on 16/5/21.
 */
@Controller
@RequestMapping(value = "api/whitelist")
public class FilterWhiteListController {

    @Autowired
    private UserService userService;

    @Autowired
    private FilterWhiteListService filterWhiteListService;

    @RequestMapping(value = "add", produces = Constant.WebConstant.JSON_FORMAT)
    @ResponseBody
    public String addWhiteList(
            @RequestParam("url") String[] urls,
            HttpSession session) {
        User user = (User)session.getAttribute("user");
        if (user.getPrivilege() == User.Privilege.Common.toInt()) {
            return ResponseUtils.returnError(ErrorInfo.NO_PRIVILEGE);
        } else {
            for (String url : urls) {
                filterWhiteListService.addWhiteList(url, user.getId());
            }
        }
        return ResponseUtils.returnOK();
    }

    @RequestMapping(value = "getAll", produces = Constant.WebConstant.JSON_FORMAT)
    @ResponseBody
    public String getAll(
            HttpSession session) {
        User user = (User)session.getAttribute("user");
        if (user.getPrivilege() == User.Privilege.Common.toInt()) {
            return ResponseUtils.returnError(ErrorInfo.NO_PRIVILEGE);
        }
        List<FilterWhiteList> filterWhiteLists = filterWhiteListService.getall();
        List<Map<String, Object>> result = new ArrayList<>();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (int i = 0; i < filterWhiteLists.size(); i++) {
            Map<String, Object> map = new HashMap<>();
            FilterWhiteList filterWhiteList = filterWhiteLists.get(i);
            map.put("id", filterWhiteList.getId());
            map.put("username", userService.getById(filterWhiteList.getOperater()).getUsername());
            map.put("url", filterWhiteList.getUrl());
            map.put("createTime", format.format(filterWhiteList.getCreateTime()));
            result.add(map);
        }
        return ResponseUtils.returnOK(result);
    }

    @RequestMapping(value = "delete", produces = Constant.WebConstant.JSON_FORMAT)
    @ResponseBody
    public String deleteWhiteList(
            @RequestParam("id") String id,
            HttpSession session) {
        User user = (User)session.getAttribute("user");
        if (user.getPrivilege() == User.Privilege.Common.toInt()) {
            return ResponseUtils.returnError(ErrorInfo.NO_PRIVILEGE);
        } else {
            filterWhiteListService.deleteWhiteList(Integer.valueOf(id), user.getId());
        }
        return ResponseUtils.returnOK();
    }
}
