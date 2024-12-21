// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract AdaptiveCurriculum {
    // Struct to represent a course
    struct Course {
        uint256 id;
        string name;
        string description;
        uint256 credits;
    }

    // Struct to represent a student
    struct Student {
        address studentAddress;
        string name;
        uint256[] enrolledCourses;
        mapping(uint256 => bool) completedCourses;
    }

    // State variables
    uint256 public nextCourseId;
    mapping(uint256 => Course) public courses;
    mapping(address => Student) public students;

    // Events
    event CourseCreated(uint256 courseId, string name, string description, uint256 credits);
    event StudentRegistered(address studentAddress, string name);
    event CourseEnrolled(address studentAddress, uint256 courseId);
    event CourseCompleted(address studentAddress, uint256 courseId);

    // Function to create a new course
    function createCourse(string memory _name, string memory _description, uint256 _credits) public {
        courses[nextCourseId] = Course(nextCourseId, _name, _description, _credits);
        emit CourseCreated(nextCourseId, _name, _description, _credits);
        nextCourseId++;
    }

    // Function to register a new student
    function registerStudent(string memory _name) public {
        Student storage student = students[msg.sender];
        require(bytes(student.name).length == 0, "Student already registered");

        student.studentAddress = msg.sender;
        student.name = _name;
        emit StudentRegistered(msg.sender, _name);
    }

    // Function to enroll a student in a course
    function enrollInCourse(uint256 _courseId) public {
        require(courses[_courseId].id == _courseId, "Course does not exist");

        Student storage student = students[msg.sender];
        require(bytes(student.name).length > 0, "Student not registered");

        student.enrolledCourses.push(_courseId);
        emit CourseEnrolled(msg.sender, _courseId);
    }

    // Function to mark a course as completed
    function completeCourse(uint256 _courseId) public {
        require(courses[_courseId].id == _courseId, "Course does not exist");

        Student storage student = students[msg.sender];
        require(bytes(student.name).length > 0, "Student not registered");

        bool isEnrolled = false;
        for (uint256 i = 0; i < student.enrolledCourses.length; i++) {
            if (student.enrolledCourses[i] == _courseId) {
                isEnrolled = true;
                break;
            }
        }

        require(isEnrolled, "Student not enrolled in course");
        require(!student.completedCourses[_courseId], "Course already completed");

        student.completedCourses[_courseId] = true;
        emit CourseCompleted(msg.sender, _courseId);
    }

    // Function to get details of a student
    function getStudentDetails(address _studentAddress) public view returns (string memory, uint256[] memory) {
        Student storage student = students[_studentAddress];
        require(bytes(student.name).length > 0, "Student not registered");

        return (student.name, student.enrolledCourses);
    }

    // Function to get course details
    function getCourseDetails(uint256 _courseId) public view returns (string memory, string memory, uint256) {
        require(courses[_courseId].id == _courseId, "Course does not exist");

        Course storage course = courses[_courseId];
        return (course.name, course.description, course.credits);
    }
}
