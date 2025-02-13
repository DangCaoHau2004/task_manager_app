# Task Manager App

## Overview

Task Manager App là một dự án quản lí công việc cho một cá nhân hoặc một tổ chức. Giúp cho người dùng quản lí công việc một cách hiệu quả.

## Features

- **Thêm task mới:** Dễ dàng thêm các task mới, với tiêu đề, ngày giờ bắt đầu và ngày giờ kết thúc.
- **Sửa và xóa task:** Mỗi task có thể sửa và xóa thông tin task, thêm người dùng, sửa quyền người dùng một cách dễ dàng.
- **Sắp xếp và tìm kiếm:** Sắp xếp các task theo ngày kết thúc, ngày bắt đầu, tên của task và chức năng tìm kiếm theo tên.
- **Thông báo:** App có chức năng thông báo nội bộ trong app, không có thông báo trên ngoài màn hình app.
- **Kết bạn và chat cơ bản:** App có chức năng kết bạn và chat với người khác.
- **Một vài chức năng khác tích hợp từ firebase auth:** Quên mật khẩu, đăng nhập, đăng kí và sửa mật khẩu.

## Download App

<a href="https://github.com/DangCaoHau2004/task_manager_app/releases/download/v1.0.0/app-release.apk">
  <img src="https://playerzon.com/asset/download.png" width="200"/>
</a>

## Technologies Used

- **Firebase**: Database và backend (FireStore và FireAuth)
- **Dart và Flutter**: UI


## Android Screenshots
  HomePage                 |   Navbar Bottom Add        |  Home Drawer
:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/homepage.png?raw=true)|![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/homepage1.png?raw=true)|![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/homepage2.png?raw=true)

  List Task                 |   Detail Task        |  Detail Table
:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/all_task.png?raw=true)|![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/detail_task.png?raw=true)|![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/all_card.png?raw=true)

  Profile                 |   Friend List        |  Notification
:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/profile.png?raw=true)|![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/friend_list.png?raw=true)|![](https://github.com/DangCaoHau2004/task_manager_app/blob/master/screenshots/notif.png?raw=true)




## Getting Started

### Yêu cầu:

- Đảm bảo bạn đã cài đặt Flutter trên máy tính của mình. Nếu chưa, hãy làm theo [hướng dẫn cài đặt Flutter](https://flutter.dev/docs/get-started/install).
- Clone repository về local.

### Installation

1. Mở terminal và di chuyển đến thư mục dự án.

2. Chạy lệnh sau:

<pre>
<code>
flutter pub get
</code>
</pre>

Chạy ứng dụng trên trình giả lập hoặc thiết bị bằng lệnh sau:

<pre>
<code>
flutter run
</code>
</pre>
