import 'package:desk4work/utils/string_resources.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class CalendarCarousel extends StatefulWidget {
  final TextStyle defaultHeaderTextStyle = TextStyle(
    fontSize: 20.0,
    color: Colors.blue,
  );
  final TextStyle defaultPrevDaysTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14.0,
  );
  final TextStyle defaultNextDaysTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14.0,
  );
  final TextStyle defaultDaysTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 14.0,
  );
  final TextStyle defaultTodayTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
  );
  final TextStyle defaultSelectedDayTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 14.0,
  );
  final TextStyle defaultWeekdayTextStyle = TextStyle(
    color: Colors.deepOrange,
    fontSize: 14.0,
  );
  final TextStyle defaultWeekendTextStyle = TextStyle(
    color: Colors.pinkAccent,
    fontSize: 14.0,
  );

  final List<String> weekDays;
  final double viewportFraction;
  final TextStyle prevDaysTextStyle;
  final TextStyle daysTextStyle;
  final TextStyle nextDaysTextStyle;
  final Color prevMonthDayBorderColor;
  final Color thisMonthDayBorderColor;
  final Color nextMonthDayBorderColor;
  final double dayPadding;
  final double height;
  final double width;
  final TextStyle todayTextStyle;
  final Color dayButtonColor;
  final Color todayBorderColor;
  final Color todayButtonColor;
  final List<DateTime> selectedDateTime;
  final TextStyle selectedDayTextStyle;
  final Color selectedDayButtonColor;
  final Color selectedDayBorderColor;
  final bool daysHaveCircularBorder;
  final Function(DateTime) onDayPressed;
  final TextStyle weekdayTextStyle;
  final Color iconColor;
  final TextStyle headerTextStyle;
  final Widget headerText;
  final TextStyle weekendTextStyle;
  final List<DateTime> markedDates;
  final Color markedDateColor;
  final Widget markedDateWidget;
  final EdgeInsets headerMargin;
  final double childAspectRatio;
  final EdgeInsets weekDayMargin;

//  If true then picking two dates will select all days between those days
  final bool isIntervalSelectable;

  CalendarCarousel({
    this.weekDays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'],
    this.viewportFraction = 1.0,
    this.prevDaysTextStyle,
    this.daysTextStyle,
    this.nextDaysTextStyle,
    this.prevMonthDayBorderColor = Colors.transparent,
    this.thisMonthDayBorderColor = Colors.transparent,
    this.nextMonthDayBorderColor = Colors.transparent,
    this.dayPadding = 2.0,
    this.height = double.infinity,
    this.width = double.infinity,
    this.todayTextStyle,
    this.dayButtonColor = Colors.transparent,
    this.todayBorderColor = Colors.red,
    this.todayButtonColor = Colors.red,
    this.selectedDateTime,
    this.selectedDayTextStyle,
    this.selectedDayBorderColor = Colors.green,
    this.selectedDayButtonColor = Colors.green,
    this.daysHaveCircularBorder,
    this.onDayPressed,
    this.weekdayTextStyle,
    this.iconColor = Colors.blueAccent,
    this.headerTextStyle,
    this.headerText,
    this.weekendTextStyle,
    this.markedDates,
    @deprecated this.markedDateColor,
    this.markedDateWidget,
    this.headerMargin = const EdgeInsets.symmetric(vertical: 16.0),
    this.childAspectRatio = 1.0,
    this.weekDayMargin = const EdgeInsets.only(bottom: 4.0),
    this.isIntervalSelectable
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarCarousel> {
  PageController _controller;
  List<DateTime> _dates = List(3);
  int _startWeekday = 0;
  int _endWeekday = 0;

  @override
  initState() {
    super.initState();

    /// setup pageController
    _controller = PageController(
      initialPage: 1,
      keepPage: true,
      viewportFraction: widget.viewportFraction,

      /// width percentage
    );
    this._setDate();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: <Widget>[
          Container(
            margin: widget.headerMargin,
            child: DefaultTextStyle(
              style: widget.headerTextStyle != null
                  ? widget.headerTextStyle
                  : widget.defaultHeaderTextStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () => _setDate(page: 0),
                    icon: Icon(
                      Icons.keyboard_arrow_left,
                      color: widget.iconColor,
                    ),
                  ),
                  Container(
                    child: widget.headerText != null
                        ? widget.headerText
                        : Text(
                      '${DateFormat.MMMM().format(this._dates[1]).toUpperCase()}',
                    ),
                  ),
                  IconButton(
                    onPressed: () => _setDate(page: 2),
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      color: widget.iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: widget.weekDays == null
                ? Container()
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: this._renderWeekDays(),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: (
                    MediaQuery.of(context).size.width * .021).toDouble()),
            decoration: BoxDecoration(border: Border.all(
                width: .5,
                color: Colors.white)),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: 3,
              onPageChanged: (value) {
                this._setDate(page: value);
              },
              controller: _controller,
              itemBuilder: (context, index) {
                return builder(index);
              },
              pageSnapping: true,
            ),
          ),
        ],
      ),
    );
  }

  builder(int slideIndex) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    int totalItemCount = DateTime(
      this._dates[slideIndex].year,
      this._dates[slideIndex].month + 1,
      0,
    ).day +
        this._startWeekday +
        (7 - this._endWeekday);
    int year = this._dates[slideIndex].year;
    int month = this._dates[slideIndex].month;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value = 1.0;
        if (_controller.position.haveDimensions) {
          value = _controller.page - slideIndex;
          value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
        }

        return Center(
          child: SizedBox(
            height: Curves.easeOut.transform(value) * widget.height,
            width: Curves.easeOut.transform(value) * screenWidth,
            child: child,
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: widget.childAspectRatio,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: List.generate(totalItemCount,

                    /// last day of month + weekday
                        (index) {
                      bool isToday =
                          DateTime
                              .now()
                              .day == index + 1 - this._startWeekday &&
                              DateTime
                                  .now()
                                  .month == month &&
                              DateTime
                                  .now()
                                  .year == year;

                      bool isNotEmptyList =  widget.selectedDateTime != null &&
                          widget.selectedDateTime.length >0;
                      bool isSelectedDay = isNotEmptyList &&
                          _isSelectedDay(year, month,
                              index + 1 - this._startWeekday);

                      bool isPrevMonthDay = index < this._startWeekday;
                      bool isNextMonthDay = index >=
                          (DateTime(year, month + 1, 0).day) +
                              this._startWeekday;

                      bool isThisMonthDay = !isPrevMonthDay && !isNextMonthDay;
                      bool isFirstDay = isNotEmptyList &&
                          _isFirstDay(year, month, index + 1 - this._startWeekday);
                      bool isLastDay = isNotEmptyList &&
                          _isLastDay(year, month, index + 1 - this._startWeekday);

                      DateTime now = DateTime(year, month, 1);
                      TextStyle textStyle;
                      TextStyle defaultTextStyle;
                      if (isPrevMonthDay) {
                        now = now
                            .subtract(
                            Duration(days: this._startWeekday - index));
                        textStyle = widget.prevDaysTextStyle;
                        defaultTextStyle = widget.defaultPrevDaysTextStyle;
                      } else if (isThisMonthDay) {
                        now = DateTime(
                            year, month, index + 1 - this._startWeekday);
                        textStyle = isSelectedDay
                            ? widget.selectedDayTextStyle
                            : widget.daysTextStyle;
                        defaultTextStyle = isSelectedDay
                            ? widget.defaultSelectedDayTextStyle
                            : widget.defaultDaysTextStyle;
                      } else {
                        now = DateTime(
                            year, month, index + 1 - this._startWeekday);
                        textStyle = widget.nextDaysTextStyle;
                        defaultTextStyle = widget.defaultNextDaysTextStyle;
                      }
                      return Container(
                        child: FlatButton(
                          color: isSelectedDay
                              ? widget.selectedDayBorderColor
                              : widget.dayButtonColor,
                          onPressed: () =>
                              widget.onDayPressed(DateTime(
                                  year, month, index + 1 - this._startWeekday)),
                          shape: _getShape(isFist: isFirstDay, isLast: isLastDay),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Center(
                                child: DefaultTextStyle(
                                  style: (index % 7 == 0 || index % 7 == 6) &&
                                      !isSelectedDay ? defaultTextStyle : defaultTextStyle,
                                  child: Text(
                                    '${now.day}',
                                    style: (index % 7 == 0 || index % 7 == 6) &&
                                        !isSelectedDay ?textStyle : textStyle,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
//                              _renderMarked(now),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setDate({
    int page,
  }) {
    if (page == null) {
      /// setup dates
      DateTime date0 =
      DateTime(DateTime
          .now()
          .year, DateTime
          .now()
          .month - 1, 1);
      DateTime date1 = DateTime(DateTime
          .now()
          .year, DateTime
          .now()
          .month, 1);
      DateTime date2 =
      DateTime(DateTime
          .now()
          .year, DateTime
          .now()
          .month + 1, 1);

      this.setState(() {
        /// setup current day
        _startWeekday = date1.weekday;
        _endWeekday = date2.weekday;
        this._dates = [
          date0,
          date1,
          date2,
        ];
      });
    } else if (page == 1) {
      return;
    } else {
      print('page: $page');
      List<DateTime> dates = this._dates;
      print('dateLength: ${dates.length}');
      if (page == 0) {
        dates[2] = DateTime(dates[0].year, dates[0].month + 1, 1);
        dates[1] = DateTime(dates[0].year, dates[0].month, 1);
        dates[0] = DateTime(dates[0].year, dates[0].month - 1, 1);
        page = page + 1;
      } else if (page == 2) {
        dates[0] = DateTime(dates[2].year, dates[2].month - 1, 1);
        dates[1] = DateTime(dates[2].year, dates[2].month, 1);
        dates[2] = DateTime(dates[2].year, dates[2].month + 1, 1);
        page = page - 1;
      }

      this.setState(() {
        _startWeekday = dates[page].weekday;
        _endWeekday = dates[page + 1].weekday;
        this._dates = dates;
      });

      print('dates');
      print(this._dates);

      _controller.animateToPage(page,
          duration: Duration(milliseconds: 1), curve: Threshold(0.0));
    }

    print('startWeekDay: $_startWeekday');
    print('endWeekDay: $_endWeekday');
  }

  List<Widget> _renderWeekDays() {
    List<Widget> list = [];
    for (var weekDay in widget.weekDays) {
      list.add(
        Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).size.height * .0165)),
              child: Center(
                child: DefaultTextStyle(
                  style: widget.defaultWeekdayTextStyle,
                  child: Text(
                    weekDay,
                    style: widget.weekdayTextStyle,
                  ),
                ),
              ),
            )),
      );
    }
    return list;
  }


  bool _isSelectedDay(int year, month, day) {
//    widget.selectedDateTime != null &&
//        widget.selectedDateTime.year == year &&
//        widget.selectedDateTime.month == month &&
//        widget.selectedDateTime.day ==
//            index + 1 - this._startWeekday;

    for (int i = 0; i < widget.selectedDateTime.length; i++) {
      DateTime dateTime = widget.selectedDateTime[i];
      if (dateTime.year == year && dateTime.month == month &&
          dateTime.day == day)
        return true;
    }
    return false;
  }

  bool _isFirstDay(int year, month, day) {
    DateTime dateTime = widget.selectedDateTime[0];
    return dateTime.year == year
        && dateTime.month == month
        && dateTime.day == day;
  }

  bool _isLastDay(int year, month, day) {
    DateTime dateTime = widget.selectedDateTime[
    widget.selectedDateTime.length - 1];
    return dateTime.year == year
        && dateTime.month == month
        && dateTime.day == day;
  }

  ShapeBorder _getShape({bool isFist, isLast}){
    if(widget.selectedDateTime.length ==1)
      return CircleBorder();
    if(isFist){
      return  RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(21.0),
            bottomLeft: Radius.circular(21.0),

          )
      );

    }else if(isLast){
      return RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(21.0),
              bottomRight: Radius.circular(21.0)));
    }

    return BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(.0))).border;


  }

}