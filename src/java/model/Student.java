/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Student {

    private String studentId;
    private String studentName;
    private String matricNo;
    private String email;
    private String phoneNumber;
    private String faculty;     // ✅ NEW
    private String password;

    public Student() {}

    // Optional full constructor (recommended)
    public Student(String studentId, String studentName, String matricNo,
                   String email, String phoneNumber, String faculty, String password) {
        this.studentId = studentId;
        this.studentName = studentName;
        this.matricNo = matricNo;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.faculty = faculty;
        this.password = password;
    }

    // ---------------- GETTERS & SETTERS ----------------

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getMatricNo() {
        return matricNo;
    }

    public void setMatricNo(String matricNo) {
        this.matricNo = matricNo;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    
    public String getFaculty() {
        return faculty;
    }

    public void setFaculty(String faculty) {
        this.faculty = faculty;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}


