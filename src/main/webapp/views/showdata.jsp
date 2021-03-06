<%@ page import="com.josie.quake.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Earthquake Eye</title>
    <link href="<%=request.getContextPath()%>/resource/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/resource/css/style.min.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/resource/js/pace.js"></script>
    <link href="<%=request.getContextPath()%>/resource/css/pace-theme-flash.min.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/resource/js/jquery-2.1.1.min.js"></script>
    <script src="<%=request.getContextPath()%>/resource/js/bootstrap.min.js"></script>
</head>
<body>
<%--<%@include file="header.jsp"%>--%>
<%@include file="system.jsp"%>
<%@include file="navbar.jsp"%>
<div class="row">
    <div class="col-md-3"></div>
    <div class="col-md-6">
        <div class="alert alert-success alert-dismissible" role="alert">
            <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span
                    aria-hidden="true">&times;</span></button>
            <h4>查看数据记录<a class="anchorjs-link" href="#"><span class="anchorjs-icon"></span></a></h4>
            <br/>

            <div class="row">
                <div class="col-lg-2"></div>
                <div class="col-lg-8" align="center">
                    <p>以下是系统收集到的符合条件的数据记录信息</p>
                </div>
                <div class="col-lg-2"></div>
            </div>
        </div>
    </div>
    <div class="col-md-3"></div>
</div>
<br/><br/>


<div class="row">
    <div class="col-md-1"></div>
    <div class="col-md-10">
        <div id="filters-div">
            <div class="row">
                <%
                    User user = (User)session.getAttribute("user");
                    if (user.getPrivilege() != User.Privilege.Common.toInt()) {
                %>
                <button type="button" class="btn btn-info" onclick="showAll()">全部</button>
                <button type="button" class="btn btn-success" onclick="showExamine()">已审核</button>
                <button type="button" class="btn btn-warning" onclick="showUnexamine()">未审核</button>
                <%
                    }
                %>
            </div>
            <br />
            <div class="row">
                <table class="table table-striped table-bordered table-hover" id="filters-table" style="table-layout: fixed;">
                    <thead>
                    <tr>
                        <th class="text-center" width="50px">序号</th>
                        <th class="text-center" width="50px">来源</th>
                        <th class="text-center" width="100px">获取时间</th>
                        <th class="text-center" width="100px">发布时间</th>
                        <th class="text-center" width="280px">标题</th>
                        <th class="text-center" width="140px">关键字</th>
                        <th class="text-center" width="60px">状态</th>
                        <th class="text-center" width="90px">审核人</th>
                        <th class="text-center" width="100px">审核时间</th>
                        <th class="text-center" width="80px">设置</th>
                    </tr>
                    </thead>
                    <tbody id="filters-tbody"></tbody>
                </table>
            </div>
            <div class="text-center">
                <nav>
                    <ul class="pagination">
                        <li id="pagePre">
                            <a href="#" aria-label="Previous" onclick="getPage(-1)">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>
                        <li class="active"><a href="#" id="pageNum">1</a></li>
                        <li id="pageNext">
                            <a href="#" aria-label="Next" onclick="getPage(1)">
                                <span aria-hidden="true">&raquo;</span>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
    </div>
    <div class="col-md-1"></div>
</div>
<script>
    var nowPage = 0, param = 0;
    var flag = false;
    function getPage(start) {
        var link = "<%=request.getContextPath()%>/api/quake/getall?count=10&status="+param+"&start=";
        if (start == -1) {
            if (nowPage == 0) {
                nowPage = 0;
                return;
            }
            else {
                nowPage --;
            }
        }
        else if (start == 1) {
            if (flag) {
                return;
            }
            nowPage++;
        }
        else if (start == 0) {
            nowPage = 0;
        }
        if (nowPage == 0) {
            $("#pagePre").attr("class", "disabled");
        }
        else {
            $("#pagePre").removeAttr("class");
        }

        $("#pageNum").text(nowPage+1);
        $.ajax({
            url: link + (nowPage*10),
            type: "GET",
            dataType: "json",
            success: function(data) {
                var jsonObj = eval(data);
                if (jsonObj.code == 0) {
                    if (jsonObj.data.length != 10) {
                        $("#pageNext").attr("class", "disabled");
                        flag = true;
                    }
                    else {
                        $("#pageNext").removeAttr("class");
                        flag = false;
                    }
                    createTable(jsonObj.data);
                }
                else {
                    alert(jsonObj.msg);
                }
            }
        });
    }
    getPage(0);

    function createTable(data) {
        document.getElementById("filters-tbody").innerHTML = "";
        for (var i = 0; i < data.length; i ++) {
            var row = document.createElement("tr");
            row.setAttribute("class", "text-info");
            var num = document.createElement("td");
            num.setAttribute("class", "text-center");
            num.innerHTML = data[i].id;
            row.appendChild(num);

            var type = document.createElement("td");
            type.setAttribute("class", "text-center");
            var span = document.createElement("span");
            span.setAttribute("class", "label label-default");
            span.innerHTML = data[i].type;
            type.appendChild(span);
            row.appendChild(type);

            var createTime = document.createElement("th");
            createTime.setAttribute("class", "text-center");
            createTime.innerHTML = data[i].createTime;
            row.appendChild(createTime);

            var pageTime = document.createElement("th");
            pageTime.setAttribute("class", "text-center");
            pageTime.innerHTML = data[i].publishTime;
            row.appendChild(pageTime);

            var title = document.createElement("th");
            title.setAttribute("class", "text-center");
            title.setAttribute("style", "overflow-x:hidden;");
            title.appendChild(document.createTextNode(data[i].title));
            row.appendChild(title);

            var desc = document.createElement("th");
            desc.setAttribute("class", "text-center");
            desc.innerHTML = data[i].description;
            row.appendChild(desc);

            var status = document.createElement("th");
            status.setAttribute("class", "text-center");
            var span_status = document.createElement("span");
            span_status.setAttribute("class", "label label-info");
            span_status.innerHTML = data[i].status;
            status.appendChild(span_status);
            row.appendChild(status);

            var examiner = document.createElement("th");
            examiner.setAttribute("class", "text-center");
            examiner.innerHTML = data[i].manager;
            row.appendChild(examiner);

            var examine_date = document.createElement("th");
            examine_date.setAttribute("class", "text-center");
            examine_date.innerHTML = data[i].verifyTime;
            row.appendChild(examine_date);

            var check = document.createElement("th");
            check.setAttribute("class", "text-center");
            var button = document.createElement("a");
            button.setAttribute("class", "btn btn-success");
            button.setAttribute("target", "_blank");
            button.setAttribute("href", data[i].jumpTo);
            button.innerHTML = "查看";
            check.appendChild(button);
            row.appendChild(check);
            document.getElementById("filters-tbody").appendChild(row);
        }
    }
</script>
<script>
    function showAll() {
        param = 0;
        getPage(0)
    }
    function showExamine() {
        param = 1;
        getPage(0)
    }
    function showUnexamine() {
        param = 2;
        getPage(0);
    }
</script>
<script src="<%=request.getContextPath()%>/resource/js/menu.js"></script>
<%@include file="footer.jsp" %>
</body>
</html>
