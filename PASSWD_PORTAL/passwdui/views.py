from django.shortcuts import render
from django.views.generic import TemplateView, ListView
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator
from django.views.decorators.cache import never_cache
from django.http import HttpResponse
from django.db.models import Q
from .models import PasswdMgmtTable

decorators = [never_cache, login_required]

@method_decorator(decorators, name='dispatch')
class HomePageView(ListView):
    template_name = 'home.html'
    model = PasswdMgmtTable
    def get_queryset(self):
        query = self.request.GET.get('host')
        if query:
            object_list = PasswdMgmtTable.objects.filter(
                Q(host_name__icontains=query) | Q(ip_addr__icontains=query)
            )
            if object_list.count() >= 1:
                object_list = [object_list.last()]
                return object_list
        else:
            object_list = None
            return object_list
        
"""class SearchResultsView(ListView):
    model = PasswdMgmtTable
    template_name = 'passwd.html'
    def get_queryset(self):
        query = self.request.GET.get('host')
        object_list = PasswdMgmtTable.objects.filter(
            Q(host_name__icontains=query) | Q(ip_addr__icontains=query)
        )
        if object_list.count() >= 1:
            object_list = [object_list.last()]
        else:
            object_list = []
        return object_list"""
        