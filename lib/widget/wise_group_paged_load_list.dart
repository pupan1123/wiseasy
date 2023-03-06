import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '/widget/wise_divider.dart';
import '/widget/wise_multi_state/wise_multi_state_widget.dart';
import '/widget/wise_pull_to_refresh.dart';
import '/widget/wise_skeleton.dart';

///分组分页加载
///T：单条数据的数据泛型
///H：分组数据的数据泛型
class WiseGroupPagedLoadList<T, E> extends StatefulWidget {
  final Key? key;

  ///分页查询方法
  final Future<List<T>> Function(Map<String, dynamic>) future;

  ///数据分组。返回单条数据的分组数据
  final E Function(T) group;

  ///初始化装载数据
  final Map<String, dynamic>? payload;

  ///单页数据大小，默认20条
  final int pageSize;

  ///行组件
  final Widget Function(T) rowBuilder;

  final int Function(T, T) itemComparator;

  final Widget? separatorBuilder;

  ///行组件
  final Widget Function(E) headerBuilder;

  final Widget? loadingWidget;

  final bool reverse;

  final bool asc;

  WiseGroupPagedLoadList({
    this.key,
    required this.future,
    required this.group,
    required this.rowBuilder,
    required this.headerBuilder,
    this.separatorBuilder,
    this.loadingWidget,
    required this.itemComparator,
    this.pageSize = 20,
    this.payload,
    this.reverse = false,
    this.asc = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => WiseGroupPagedLoadListState<T, E>();
}

class WiseGroupPagedLoadListState<T, E> extends State<WiseGroupPagedLoadList> {
  ///所有数据集合
  List<T> _data = [];

  ///页码
  int _pageNum = 1;

  ///装载数据
  Map<String, dynamic>? _payload;

  @override
  void initState() {
    _payload = widget.payload;
    super.initState();
  }

  var multiStateKey = GlobalKey<WiseMultiStateWidgetState>();

  @override
  Widget build(BuildContext context) {
    return WiseMultiStateWidget(
      key: multiStateKey,
      future: () async {
        return await _loadMore();
      },
      loadingWidget: widget.loadingWidget ??
          WiseSkeleton(
            wiseSkeletonType: WiseSkeletonType.listView,
            mainAxisCount: 20,
          ),
      successWidget: WisePullToRefresh(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () async {
          await _refresh();
        },
        onLoading: () async {
          return await _loadMore();
        },
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: GroupedListView<T, E>(
                  shrinkWrap: true,
                  reverse: widget.reverse,
                  order:
                      widget.asc ? GroupedListOrder.ASC : GroupedListOrder.DESC,
                  elements: _data,
                  groupBy: (T t) {
                    return (widget as WiseGroupPagedLoadList<T, E>).group(t);
                  },
                  groupComparator: (e1, e2) {
                    return (e2 as Comparable).compareTo(e1 as Comparable);
                  },
                  itemComparator: (item1, item2) {
                    return (widget as WiseGroupPagedLoadList<T, E>)
                        .itemComparator(item1, item2);
                  },
                  itemBuilder: (BuildContext context, T t) {
                    return (widget as WiseGroupPagedLoadList<T, E>)
                        .rowBuilder(t);
                  },
                  separator: widget.separatorBuilder ?? WiseDivider(),
                  groupSeparatorBuilder: (E e) {
                    return (widget as WiseGroupPagedLoadList<T, E>)
                        .headerBuilder(e);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  ///获取数据
  Future<List<T>> _fetchData({int? pageNum}) async {
    Map<String, dynamic> params = Map<String, dynamic>();
    params["page_num"] = pageNum ?? _pageNum;
    params["page_size"] = widget.pageSize;
    if (null != _payload) {
      _payload!.forEach((key, value) {
        if (null != value) params[key] = value;
      });
    }
    return await (widget as WiseGroupPagedLoadList<T, E>).future(params);
  }

  ///上拉加载更多
  Future<bool> _loadMore() async {
    List<T> newData = await _fetchData();
    if (newData.length > 0) {
      setState(() {
        _data.addAll(newData);
        _pageNum++;
      });
    }
    return newData.length > 0;
  }

  ///下拉刷新
  Future<bool> _refresh() async {
    _pageNum = 1;
    List<T> newData = await _fetchData();
    if (newData.length == 0) {
      multiStateKey.currentState!.forceShowEmptyView();
    } else {
      multiStateKey.currentState!.forceShowSuccessView();
    }
    if (newData.length > 0) {
      setState(() {
        _data.clear();
        _data.addAll(newData);
        _pageNum++;
      });
    }
    return newData.length > 0;
  }

  ///重置装载数据
  Future<void> resetPayload(Map<String, dynamic>? payload,
      {bool replaceAll = true}) async {
    ///全部替换参数
    if (replaceAll) {
      _payload = payload;
    } else {
      ///增量替换参数
      if (_payload == null) {
        _payload = Map<String, dynamic>();
      }
      payload!.forEach((key, value) {
        _payload![key] = value;
      });
    }
    await _refresh();
  }

  ///重置装载数据
  Future<void> reload() async {
    await _refresh();
  }
}
