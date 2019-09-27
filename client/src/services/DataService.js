import Api from '@/services/Api'

export default {
	pullInitialStats (){
		return Api().post('pullInitialStats')
	}
}