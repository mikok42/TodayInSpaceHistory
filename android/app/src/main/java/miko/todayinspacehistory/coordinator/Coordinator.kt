package miko.todayinspacehistory.coordinator

interface Coordinator {
    val childCoordinators: MutableList<Coordinator>
    fun start()
}
